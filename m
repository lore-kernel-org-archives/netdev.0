From: Sam Leffler <sam@errno.com>
Subject: [Fwd: how do I request an ARPHRD_ constant?]
Date: Sat, 13 Nov 2004 23:43:11 -0800
Message-ID: <41970C8F.6020909@errno.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry if this is in some faq...

-------- Original Message --------
Subject: how do I request an ARPHRD_ constant?
Date: Mon, 1 Nov 2004 16:41:12 -0700
From: Sam Leffler <sam@errno.com>
Organization: Errno Consulting
To: Jeff Garzik <jgarzik@pobox.com>

Can you tell me how to get an ARPHRD_ constant allocated?  This would be 
for
an 802.11 packet capture format (different than the existing ones).  If
you're the right person then I'm looking for something like

#define ARPHDR_IEEE80211_RADIO 803 /* IEEE 802.11 + radiotap */

Thanks.

  Sam
