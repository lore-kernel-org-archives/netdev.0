From: Simon Kelley <simon@thekelleys.org.uk>
Subject: Re: [PATCH 2.6.11-rc2 1/2] wireless: Clean up firmware loading in
 Atmel driver
Date: Wed, 02 Feb 2005 20:39:14 +0000
Message-ID: <42013A72.1080209@thekelleys.org.uk>
References: <1107357472.27197.5.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@redhat.com
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1107357472.27197.5.camel@dcbw.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All Dans patches look good, in principle, to me.

There's one more entry to go in the device table which has been floating 
around for a month or two, but doesn't seem to have made it in yet,

in the new format:

{0, 0," LG/LW2100N", ATMEL_FW_TYPE_502E, "LG LW2100N 11Mbps WLAN PCMCIA 
Card" }

Dan, if you make another version of your patch maybe you could add that, 
otherwise I'll submit it as a follow-on once your changes have gone in.


Cheers,

Simon.
