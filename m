From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Update on e1000 troubles (over-heating!)
Date: Sun, 6 Oct 2002 00:33:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <288F9BF66CD9D5118DF400508B68C44604758AF7@orsmsx113.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
   "'netdev@oss.sgi.com'"
	 <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Ben Greear'" <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I believe I have figured out why the e1000 crashed my machine 
> after .5 - 1 hours:  The NIC was over-heating.  I measured 
> one of the NICs after the machine crashed with an external 
> (cheap) temp probe.  It registered right at 50 degrees C, and 
> this was about 15-30 seconds after it crashed.

Ben, please send lspci -x on the hot nic.

-scott
