From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v7 8/8] openvswitch: Add vxlan tunneling support.
Date: Mon, 19 Aug 2013 17:25:16 -0700
Message-ID: <CAEP_g=-d+2kYdeVkBP+gYeJ0wB8F+g=pTRxdmHzqnuiJ1EVMLw@mail.gmail.com>
References: <1376936614-25770-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:43686 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751356Ab3HTAay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 20:30:54 -0400
Received: by mail-la0-f53.google.com with SMTP id el20so3868180lab.12
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 17:30:53 -0700 (PDT)
In-Reply-To: <1376936614-25770-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 19, 2013 at 11:23 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch adds vxlan vport type for openvswitch using
> vxlan api. So now there is vxlan dependency for openvswitch.
>
> CC: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: Jesse Gross <jesse@nicira.com>
