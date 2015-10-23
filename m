From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [ovs-dev] [RFC PATCH 2/3] tests: Enable debugging in pyftpdlib.
Date: Fri, 23 Oct 2015 16:20:46 -0700
Message-ID: <CANr6G5xNYtO4s77bBAkvLs5-oNPUP-yL9E4PuFOgxT56=BAWjg@mail.gmail.com>
References: <1445379840-113042-1-git-send-email-jrajahalme@nicira.com> <1445379840-113042-2-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:35363 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbbJWXVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 19:21:07 -0400
Received: by ykaz22 with SMTP id z22so136483035yka.2
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 16:21:05 -0700 (PDT)
In-Reply-To: <1445379840-113042-2-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20 October 2015 at 15:23, Jarno Rajahalme <jrajahalme@nicira.com> wrote:
> Helps diagnosing problems.
>
> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>

I assume we don't check the output of this anywhere, so we don't need
to amend the testsuite to keep things passing.

Acked-by: Joe Stringer <joestringer@nicira.com>
