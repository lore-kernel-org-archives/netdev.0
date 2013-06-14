From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 4/4] openvswitch: make skb->csum consistent
 with rest of networking stack.
Date: Fri, 14 Jun 2013 07:44:33 -0700
Message-ID: <CAEP_g=-EiovY5u8W=mvK=RrWtouAgGUWWA7NgN64Fxo9ukXBCg@mail.gmail.com>
References: <1371147104-29295-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:43814 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752494Ab3FNOpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 10:45:18 -0400
Received: by mail-ie0-f174.google.com with SMTP id 9so1567521iec.5
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 07:45:07 -0700 (PDT)
In-Reply-To: <1371147104-29295-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 13, 2013 at 11:11 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch keeps skb->csum correct across ovs.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
