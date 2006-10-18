From: Kel Modderman <kelmo@kanotixguide.org>
Subject: Re: [Madwifi-devel] d80211: ANNOUNCE: DadWifi, a port of MadWifi to d80211
Date: Wed, 18 Oct 2006 10:42:17 +1000
Message-ID: <200610181042.17944.kelmo@kanotixguide.org>
References: <20061018001403.GA22990@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs161192.vserver.de ([62.75.161.192]:45978 "EHLO
	vs161192.vserver.de") by vger.kernel.org with ESMTP
	id S1751190AbWJRAlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 20:41:20 -0400
To: madwifi-devel@lists.sourceforge.net
In-Reply-To: <20061018001403.GA22990@devicescape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 18 October 2006 10:14, David Kimdon wrote:
> Hi,
>
> DadWifi is a port of MadWifi to the d80211 stack.  It works now in
> managed and monitor mode, lightly tested.  Any card supported by
> MadWifi should be supported by DadWifi [1].  This allows a large
> number of cards to now take advantage of the d80211 stack.
>
> DadWifi uses the same (binary only) hal as MadWifi and reuses much of
> the initialization, descriptor and interrupt processing code.
>
> There is a subversion repository and mailing list available [2] for
> those wishing to try it out or help with development.

Any chance you would consider joining effort with the current MadWifi team and 
infrastructure (existing mailing lists, developers, subversion archive, bug 
tracking etc etc) at madwifi.org, or is this a strictly in-house or separate 
undertaking?

Thanks, Kel.
