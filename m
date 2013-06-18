From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next v2 00/12] openvswitch: gre tunneling support.
Date: Tue, 18 Jun 2013 11:05:56 -0700
Message-ID: <CAEP_g=-PiA7gCqFmNsjT9jvhkQgHbjUBBxcWLwqKwJXUC8T0bQ@mail.gmail.com>
References: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:47561 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932872Ab3FRSGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 14:06:18 -0400
Received: by mail-ie0-f170.google.com with SMTP id e11so10979314iej.1
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 11:06:16 -0700 (PDT)
In-Reply-To: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 17, 2013 at 5:49 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch series adds support for gre tunneling.
> First six patches extend kernel gre and ip_tunnel modules
> api so that there is more code sharing between gre modules
> and ovs. Rest of patches adds ovs tunneling infrastructre
> and gre protocol vport.

For the OVS portions:
Acked-by: Jesse Gross <jesse@nicira.com>

Thanks Pravin!
