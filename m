From: "Dr. Peter Bieringer" <pb@bieringer.de>
Subject: sundance driver does not work with D-Link DFE-580TX
Date: Mon, 26 May 2003 16:27:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6530000.1053959277@klopffest.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

pls. take a look into:

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=69000

Looks like current included "sundance.c" driver doesn't work proper 
together with current "mii.c" on a D-Link DFE-580TX.

Can someone else doublecheck this?

If confirmed, who can trigger the update of "sundance.c" driver from 
version 1.06 (shipped in 2.4.20 and 2.4.21-pre3) to 1.10?

TIA,
	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
