From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 18 Jul 2008 16:02:40 +0200
Message-ID: <200807181602.42338.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807181114.53059.thomas.jarosch@intra2net.com> <Pine.LNX.4.64.0807181617550.24938@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?iso-8859-15?q?D=E2niel?= Fraga" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0807181617550.24938@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, 18. July 2008 15:55:22 Ilpo J=E4rvinen wrote:
> Btw, on which kernel you ran these things (I hope it wasn't 2.6.24.7,
> which has FRTO related bugs anyway that the patches I've sent now won=
't
> fix)?

It's the git "master" tree from two days ago, so it should be 2.6.27-pr=
e.
Like I wrote before, there's another box doing NAT in front of it runni=
ng=20
2.6.24.7. FRTO is disabled on that box. Hope that helps a bit.

Thomas
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
