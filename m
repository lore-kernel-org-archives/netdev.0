From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v3 0/6] openvswitch: VXLAN tunneling.
Date: Thu, 25 Jul 2013 11:33:02 -0700
Message-ID: <CAEP_g=9_AWgGY9-pZnGSgk7XMScszUCvcUzzyB7=9FKAjO9iEA@mail.gmail.com>
References: <1374688826-14199-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:42247 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757649Ab3GYSdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 14:33:23 -0400
Received: by mail-ob0-f178.google.com with SMTP id fb19so2265746obc.23
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 11:33:22 -0700 (PDT)
In-Reply-To: <1374688826-14199-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 24, 2013 at 11:00 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> First two patches extends vxlan so that openvswitch can
> share vxlan udp port with vxlan module. Rest of patches
> refactors vxlan data plane so that ovs can share that
> code with vxlan module.
> Last patch adds vxlan-vport to openvswitch.

Stephen, will you take the first five so I can take the last one?
