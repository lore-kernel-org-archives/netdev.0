From: Jiri Benc <jbenc@suse.cz>
Subject: Re: ieee80211 patches
Date: Fri, 26 Aug 2005 14:08:31 +0200
Message-ID: <20050826140831.5ec0f301@griffin.suse.cz>
References: <20050825193112.529d0dc9@griffin.suse.cz>
	<200508252049.52413.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, NetDev <netdev@vger.kernel.org>,
        Jeff Garzik <jgarzik@pobox.com>, jbohac@suse.cz, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200508252049.52413.flamingice@sourmilk.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 25 Aug 2005 20:49:52 -0400, Michael Wu wrote:
> I hope to submit the adm8211 driver for review soon, but there's a bunch of 
> code in the driver which probably belong in the ieee80211 code:
> 
> - Duplicate frame removal
> - Definitions for all management payloads
> - SIOCSIWENCODEEXT and SIOCGIWENCODEEXT
> - AVS capture header in monitor mode
> - Software Scanning
> - Software Authentication & Association
> 
> Does that sound okay? I will start submitting patches to add those things if 
> they should be in the ieee80211 code.

Sounds great. Could you post a pointer to the project?

Btw, Andrea Merello has a code for some of these features in his
rtl8180-sa2400 project (http://sourceforge.net/projects/rtl8180-sa2400)
too - we are trying to subsequently include them.

Thanks,

-- 
Jiri Benc
SUSE Labs
