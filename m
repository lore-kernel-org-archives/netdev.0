From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Mon, 1 Dec 2008 09:17:58 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0812010916570.16044@quilx.com>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Raz <raziebe@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi053.sbcis.sbc.com ([207.115.36.82]:38325 "EHLO
	nlpi053.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbYLAPSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 10:18:14 -0500
In-Reply-To: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note also that the performance of NICs may be descreasing over time.
Network latency for myricom drivers for example doubled between .22 and
.28-rc6.

