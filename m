From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.12.1 1/12] S2io: Code cleanup
Date: Sun, 31 Jul 2005 01:11:50 -0400
Message-ID: <42EC5D96.3050304@pobox.com>
References: <20050707220506.A8AC689826@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: raghavendra.koushik@neterion.com
In-Reply-To: <20050707220506.A8AC689826@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

patch doesn't seem to apply :(

Can you please resend the entire series, taking into account the 
comments WRT patch #5?

Also, I was unable to include your fixes in my 'fixes' branch, whose 
speed to upstream kernel is accelerated, because patch #1 was not bug fixes.

If you want your bug fixes to go upstream as rapidly as possible, make 
sure they are ordered before the code cleanups and new features.  This 
allows me to send the fixes upstream immediately, while allowing further 
review and testing of the cleanup/feature patches.

	Jeff
