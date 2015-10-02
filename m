From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 2/4] openvswitch: netlink attributes for IPv6 tunneling
Date: Thu, 1 Oct 2015 17:10:57 -0700
Message-ID: <CALnjE+qiL4warx0nLwvN8M2f39QnebFBBA4BuSXRkR7yphOfHQ@mail.gmail.com>
References: <cover.1443710454.git.jbenc@redhat.com>
	<57d072dd1b31821743d0ae92a93b842022118f76.1443710454.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Jesse Gross <jesse@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34486 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbbJBAK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 20:10:58 -0400
Received: by igcpb10 with SMTP id pb10so7795497igc.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 17:10:57 -0700 (PDT)
In-Reply-To: <57d072dd1b31821743d0ae92a93b842022118f76.1443710454.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 1, 2015 at 7:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Add netlink attributes for IPv6 tunnel addresses. This enables IPv6 support
> for tunnels.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> v2: Changed description. Rebased tun_proto assignment in ip_tun_from_nlattr
>     to accomodate changes in the previous patch.
> ---
Acked-by: Pravin B Shelar <pshelar@nicira.com>
