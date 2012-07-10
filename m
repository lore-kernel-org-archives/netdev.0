From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: 82571EB: Detected Hardware Unit Hang
Date: Tue, 10 Jul 2012 18:14:23 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B62627502B8E@ORSMSX102.amr.corp.intel.com>
References: <4FFA9B96.6040901@oracle.com> <4FFBDC50.5090800@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FFBDC50.5090800@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Joe Jin
>Sent: Tuesday, July 10, 2012 12:40 AM
>To: Joe Jin
>Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Subject: Re: 82571EB: Detected Hardware Unit Hang
[..]
>I checked all driver codes I did not found anywhere will set the
>upper.data with
>E1000_TXD_STAT_DD, I guess upper.data be set by hardware?

Yes, the hw sets this bit after transmit, its how the driver knows to reclaim it.

>> Would you please help on this?

Yes, we'll attempt to reproduce it and get back to you with any more needed info.  I'm sorry you're having problems with our parts.

Thanks for the report,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
