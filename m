From: Andi Kleen <ak@suse.de>
Subject: Re: status of ipchains in 2.6?
Date: 28 Oct 2003 15:31:09 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <p733cdda0ya.fsf@oldwotan.suse.de>
References: <200310280127.h9S1RM5d002140@napali.hpl.hp.com.suse.lists.linux.kernel>
	<20031028090304.GA19302@lps.ens.fr.suse.lists.linux.kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davidm@hpl.hp.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, davem@redhat.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: =?iso-8859-1?q?=C9ric?= Brunet <Eric.Brunet@lps.ens.fr>
In-Reply-To: <20031028090304.GA19302@lps.ens.fr.suse.lists.linux.kernel>
List-Id: netdev.vger.kernel.org

=C9ric Brunet <Eric.Brunet@lps.ens.fr> writes:
>=20
> In my case, 2.6.0-test4 is working fine.

Can you do a binary search in the versions to see which version
broke it?=20

test5-test8 all had netfilter changes.

-Andi
