From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Update on e1000 troubles (over-heating!)
Date: Mon, 14 Oct 2002 19:20:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <288F9BF66CD9D5118DF400508B68C44604758B78@orsmsx113.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
   "'netdev@oss.sgi.com'"
	 <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Ben Greear'" <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Here is the lspci information, both -x and -vv.  This is with 
> two of the e1000 single-port NICS side-by-side.  I have also 
> strapped a P-IV CPU fan on top of the two cards to blow some 
> air over them....running tests now to see if that actually 
> helps anything.  If it does, I'll be sure to send you a picture :)

Ben, I checked the datasheet for the part shown in the lspci dump, and it
shows an operating temperature of 0-55 degrees C.  You said you measured 50
degrees C, so you're within the safe range.  Did the fans help?

Here's the datasheet:
http://www.intel.com/network/connectivity/resources/doc_library/data_sheets/
pro1000mt_sa.pdf

-scott
