From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2] packet: tx timestamping on tpacket ring
Date: Sun, 21 Apr 2013 20:14:43 +0200
Message-ID: <51742C93.1010307@redhat.com>
References: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com> <1366408317-16432-1-git-send-email-willemb@google.com> <51728B32.4040200@redhat.com> <CA+FuTSckxSB-rDFVJbbWdxX=5HfNoD4vwkeHy71Ab2cam8wpGQ@mail.gmail.com> <5173BB0F.90900@redhat.com> <CA+FuTSc9ikN6gOsnKjM4Gv-2M+W-_jwijW4Wy=_RLLuRxoJw9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Paul Chavent <paul.chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218Ab3DUSPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 14:15:10 -0400
In-Reply-To: <CA+FuTSc9ikN6gOsnKjM4Gv-2M+W-_jwijW4Wy=_RLLuRxoJw9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/2013 06:42 PM, Willem de Bruijn wrote:
> win. Since it is a strict superset, how about I send the current patch
> as is (with extra documentation) and you submit the hw tstamp support
> + labels separately?

Ok, we could do that.
