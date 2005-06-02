From: <gwingerde@home.nl>
Subject: Antw: Re: [PATCH] ieee80211: Update generic definitions to latest specs.
Date: Thu, 2 Jun 2005 21:02:24 +0200
Message-ID: <200506021903.j52J3QXq012315@oss.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <jgarzik@pobox.com>, <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Jun 2005, Jiri Benc wrote:
> On Wed, 01 Jun 2005 22:50:51 +0200, Gertjan van Wingerde wrote:
> > +#define WLAN_STATUS_ASSOC_DENIED_SPECTRUM_MGMT_REQUIRED 22
> > +#define WLAN_STATUS_ASSOC_REJECTED_POWER_CAP_UNACCEPTABLE 23
> > +#define WLAN_STATUS_ASSOC_REJECTED_SUPP_CHANNELS_UNACCEPTABLE 24
> > (...)
> > +/* 802.11h */
> > +#define WLAN_REASON_DISASSOC_POWER_CAP_UNACCEPTABLE 10
> > +#define WLAN_REASON_DISASSOC_SUPP_CHANNELS_UNACCEPTABLE 11
> 
> Aren't these identifiers a bit too long? It seems to be unpractical to use
> them.
> 

I was thinking about that too, but couldn't find a proper shorter
version without losing the descriptive meaning.

Do you have any suggestions to shorten them?

BR, Gertjan
