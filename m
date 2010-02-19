From: Patrick McHardy <kaber@trash.net>
Subject: Re: kernel stack  trace using conntrack
Date: Fri, 19 Feb 2010 14:25:34 +0100
Message-ID: <4B7E914E.50900@trash.net>
References: <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D04@FRSPX100.fr01.awl.atosorigin.net>	 <1266313889.3045.1.camel@edumazet-laptop>	 <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D54@FRSPX100.fr01.awl.atosorigin.net>	 <1266318928.3045.38.camel@edumazet-laptop>  <4B7A9E95.103@netfilter.org>	 <1266327917.3045.55.camel@edumazet-laptop>	 <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC905D@FRSPX100.fr01.awl.atosorigin.net>	 <4B7D17CE.6010805@trash.net> <4B7D1E32.6000705@netfilter.org>	 <4B7D215A.6060400@trash.net> <4B7D3022.9030405@netfilter.org>	 <4B7D306F.9060808@trash.net>  <4B7DF4DC.4000502@netfilter.org> <1266582824.3136.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Ramblewski David <David.Ramblewski@atosorigin.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58888 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab0BSNZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 08:25:36 -0500
In-Reply-To: <1266582824.3136.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le vendredi 19 f=E9vrier 2010 =E0 03:18 +0100, Pablo Neira Ayuso a =E9=
crit :
>> I have slightly tested the following patch here. I think it should f=
ix
>> the problem.
>>
>> We can revisit ctnetlink_change_helper() later, I think there's some
>> code there that can be refactorized.
>>
>> Let me know if you're OK with it.
>=20
> I sucessfuly tested your patch Pablo, thanks.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
