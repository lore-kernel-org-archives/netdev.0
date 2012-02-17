From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [B.A.T.M.A.N.] pull request: batman-adv 2012-02-17
Date: Fri, 17 Feb 2012 21:01:48 +0000
Message-ID: <20120217210148.GA9935@sirena.org.uk>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
 <20120217.152323.2251437927591117547.davem@davemloft.net>
 <1990573.JisbTKXt7B@sven-laptop.home.narfation.org>
 <20120217.155049.1321221133602638857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sven@narfation.org, b.a.t.m.a.n@lists.open-mesh.org,
	lindner_marek@yahoo.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:52526 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772Ab2BQVBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 16:01:53 -0500
Content-Disposition: inline
In-Reply-To: <20120217.155049.1321221133602638857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2012 at 03:50:49PM -0500, David Miller wrote:

> I'm reluctant to pull tags which are signed, I certainly don't have
> your personal keys in my key ring for example.  And distributions
> ship with GIT versions that don't support signed tags, so...

The signed tags interoperate fine with old versions, you won't be able
to validate them but they shouldn't cause any hassle.  If the key can't
be verified then that might be more of an issue but if you're OK with
pulling something that's completely unsigned you're not loosing
anything, it'll just record the signature.
