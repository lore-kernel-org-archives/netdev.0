From: "Eugene Teo" <eugeneteo@kernel.sg>
Subject: Re: [PATCH] dccp: change L/R must have at least one byte in the dccpsf_val field
Date: Thu, 14 Aug 2008 09:08:56 +0800
Message-ID: <28fa9c5e0808131808x40a2e902jeccf962dd86cfb32@mail.gmail.com>
References: <20080813125532.GD12888@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Arnaldo Carvalho de Melo" <acme@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Gerrit Renker" <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:47021 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941AbYHNBI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 21:08:57 -0400
Received: by yx-out-2324.google.com with SMTP id 8so158366yxm.1
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 18:08:56 -0700 (PDT)
In-Reply-To: <20080813125532.GD12888@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 8:55 PM, Arnaldo Carvalho de Melo
<acme@redhat.com> wrote:
> Hi David, Gerrit,
>
>        Please consider applying.
>
> - Arnaldo
>
> dccp: change L/R must have at least one byte in the dccpsf_val field
>
> Thanks to Eugene Teo for reporting this problem.
>
> Signed-off-by: Eugene Teo <eugenete@kernel.sg>

Should be eugeneteo@ instead of eugenete. Thanks.

Eugene
