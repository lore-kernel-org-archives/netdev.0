From: Don Fry <brazilnut@us.ibm.com>
Subject: driver version string changes
Date: Mon, 24 May 2004 12:40:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405241940.i4OJedx24559@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

What is the correct approach in dealing with version strings in drivers?
For my own sanity, I need to change the version string as I make changes
to the driver.  Some drivers and the kernel use a nn.nn.nn format while
others use nn.nn and others use nn.nnsss, where nn is a number and sss is
a character or string.  The pcnet32 does a mixture, and I have recently
added to that inconsistency.

What is the recommendation for version strings in Linux drivers, and what
have I not read that already answers this question?

-- 
Don Fry
brazilnut@us.ibm.com
