From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Please pull - generic HDLC
Date: Mon, 13 Oct 2008 16:53:17 +0200
Message-ID: <m31vyk4kde.fsf@maximus.localdomain>
References: <m33aj15xhr.fsf@maximus.localdomain>
	<20081012.144704.39192150.davem@davemloft.net>
	<20081013055356.GA29938@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759363AbYJMOxe@vger.kernel.org>
In-Reply-To: <20081013055356.GA29938@cs181140183.pp.htv.fi> (Adrian Bunk's message of "Mon\, 13 Oct 2008 08\:53\:56 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@kernel.org> writes:

> The over 3 weeks old -next already contains mostly the same as the HDLC 
> tree contains now.
>
> The thing you two should sort out is why the tree ended up as an own 
> tree in -next instead of pull requests to David long ago.
>
> E.g. the netdev and wireless trees also don't go into -next, but instead 
> with frequent pull requests to David.

I can't see any problem with this, is there any?

I want the HDLC tree tested in next before it's merged upstream
(= David's tree(s)). I don't want to push crap upstream  first and
only then try to fix it (though a bug still slips in sometimes).
-- 
Krzysztof Halasa
