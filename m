From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 0/3] Fix checkpatch errors in drivers/isdn/isdnloop
Date: Wed,  4 Feb 2015 23:32:58 +0100
Message-ID: <1423089181-15850-1-git-send-email-baspeters93@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adresses various checkpatch errors in the abovementioned driver.

Bas Peters (3):
  drivers: isdn: isdnloop: isdnloop.c: remove assignment of variables in
    if conditions,     in accordance with the CodingStyle.
  drivers: isdn: isdnloop: isdnloop.c: Fix brace positions according to 
       CodingStyle specifications.
  drivers: isdn: isdnloop: isdnloop.c: Remove parenthesis around return 
       values, as specified in CodingStyle.

 drivers/isdn/isdnloop/isdnloop.c | 64 +++++++++++++++++++---------------------
 1 file changed, 30 insertions(+), 34 deletions(-)

-- 
2.1.0
