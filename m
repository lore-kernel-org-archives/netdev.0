From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 0/5] 2.6.6-bk8 pcnet32.c
Date: Fri, 21 May 2004 13:26:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405212026.i4LKQcP10151@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply the following patches to 2.6.6.  The first four are simple
"one line" fixes. The last removes the timer I added a little while ago,
as it added complexity without improving performance.

[PATCH 1/5] 2.6.6-bk8 pcnet32 add static to two routines.
[PATCH 2/5] 2.6.6-bk8 pcnet32 avoid hard hang with some chip variants.
[PATCH 3/5] 2.6.6-bk8 pcnet32 correct 79C976 variant string.
[PATCH 4/5] 2.6.6-bk8 pcnet32 fix boundary comparison bug.
[PATCH 5/5] 2.6.6-bk8 pcnet32 remove timer and complexity.

-- 
Don Fry
brazilnut@us.ibm.com
