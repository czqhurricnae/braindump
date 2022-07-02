BASE_DIR=${shell pwd}
NOTES_ORG_FILES=${BASE_DIR}/notes
EMACS_BUILD_DIR=/tmp/notes-home-build/
BUILD_DIR=/tmp/notes-home-build/.cache/org-persist/

all: org2hugo

.PHONY: org2hugo
org2hugo:
	mkdir -p $(BUILD_DIR)
	cp -r $(BASE_DIR)/github-online-publish.el $(EMACS_BUILD_DIR)
  # Build temporary minimal EMACS installation separate from the one in the machine.
	HOME=$(EMACS_BUILD_DIR) NOTES_ORG_SRC=$(NOTES_ORG_FILES) HUGO_BASE_DIR=$(BASE_DIR) emacs -Q --batch --load $(EMACS_BUILD_DIR)/github-online-publish.el --execute "(hurricane/publish)" --kill
