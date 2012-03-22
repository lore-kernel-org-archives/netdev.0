From: Oliver Neukum <oneukum@suse.de>
Subject: Re: use-after-free in usbnet
Date: Thu, 22 Mar 2012 10:57:36 +0100
Message-ID: <201203221057.36669.oneukum@suse.de>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com> <201203221008.46882.oneukum@suse.de> <CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>,
	Dave Jones <davej@redhat.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52410 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753600Ab2CVJ5W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 05:57:22 -0400
In-Reply-To: <CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 22. M=E4rz 2012, 10:30:36 schrieb Ming Lei:
> On Thu, Mar 22, 2012 at 5:08 PM, Oliver Neukum <oneukum@suse.de> wrot=
e:
> >
> > this looks good, but could you add a comment explaining the reason =
for
> > taking a reference?
>=20
> OK, I will post a formal one if you have no objection on the below.

Good patch :-)

	Regards
		Oliver
