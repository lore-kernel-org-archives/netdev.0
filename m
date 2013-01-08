From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 0/5] ipv4_tunnels: Modularize ipv4 tunneling.
Date: Tue, 8 Jan 2013 23:10:57 +0200
Message-ID: <CAJZOPZK1wwno3wvu30v_HGm--R-SOYEP+SjK-sOc6F40iGb0QA@mail.gmail.com>
References: <1357612292-1682-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:40140 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946Ab3AHVK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 16:10:58 -0500
Received: by mail-qc0-f177.google.com with SMTP id u28so1081097qcs.36
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 13:10:57 -0800 (PST)
In-Reply-To: <1357612292-1682-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 8, 2013 at 4:31 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch series restructure GRE and IPIP tunneling code
> to make it modular. It adds ip_tunnel module which acts as
> generic tunneling layer which has common code. I have patch
> to do same for VXLAN too. [..]

Can you be more specific re the vxlan patch?

Or.
