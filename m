From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 13:44:29 -0500
Message-ID: <20091012184429.GA5190@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <7e84ed60910111410g52ffd52bjec62576570d4b460@mail.gmail.com> <20091012030008.GA8436@kroah.com> <7e84ed60910121135j656d1d9s8d84757e7e3d0078@mail.gmail.com>
Reply-To: Matt Domsch <Matt_Domsch@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Rob Townley <rob.townley@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:48791 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbZJLSpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 14:45:07 -0400
Content-Disposition: inline
In-Reply-To: <7e84ed60910121135j656d1d9s8d84757e7e3d0078@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2009 at 01:35:25PM -0500, Rob Townley wrote:
> > Again, is what we currently have broken? =A0I am confused as to wha=
t this
> > is referring to.
>=20
> Yes, ping and traceroute are broken at least on Fedora, CentOS, and b=
usybox.
> On a multinic, multigatewayed machine, passing ethX instead of the IP
> address will give the false result: "Destination Host Unreachable"
> when the machine's default gateway is reached thru the other nic.   I=
n
> the following example, the default gateway is thru eth1, not eth0.

Unrelated to this thread.  We're having a hard enough time making sure
this conversation accurately reflects the views and needs of everyone
involved.  Please let's not throw in another tangent.

Thanks,
Matt

--=20
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
