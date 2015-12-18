From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH iproute2] iplink: support 'stable-privacy' IPv6 addrgenmode
Date: Fri, 18 Dec 2015 13:26:28 +0100
Message-ID: <87y4cs0wp7.fsf@nemi.mork.no>
References: <1450278914-12717-1-git-send-email-bjorn@mork.no>
	<20151217173238.7c742fb1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41932 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbbLRM0m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 07:26:42 -0500
In-Reply-To: <20151217173238.7c742fb1@xeon-e3> (Stephen Hemminger's message of
	"Thu, 17 Dec 2015 17:32:38 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:
> On Wed, 16 Dec 2015 16:15:14 +0100
> Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>
> Does not apply to current code base. Probably because of Hannes recen=
t changes.

Yes, I saw that you applied Hannes' ipaddress.c patch, which conficts
with this one.  No problem, either way is fine by me.  I'll redo the ma=
n
page thing as part of the next round for "addrgenmode random", if/when
that is applied to the kernel.

BTW, I didn't understand your comment regarding Hannes' iplink.c patch.
If the ipaddress patch is OK, then the iplink patch is just the part
missing for show/set symmetry.  Or did I misunderstand something?


Bj=C3=B8rn
