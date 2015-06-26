From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Add displaying VF traffic statistics
Date: Thu, 25 Jun 2015 23:59:18 -0400
Message-ID: <20150625235918.20d80723@uryu.home.lan>
References: <1434445996-2493-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:33563 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbFZD7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 23:59:39 -0400
Received: by igin14 with SMTP id n14so3138346igi.0
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 20:59:39 -0700 (PDT)
In-Reply-To: <1434445996-2493-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Jun 2015 12:13:16 +0300
Or Gerlitz <ogerlitz@mellanox.com> wrote:

> From: Eran Ben Elisha <eranbe@mellanox.com>
> 
> Enable reading and displaying SRIOV VFs traffic statistics through 
> the host PF netdevice using the nested IFLA_VF_STATS attribute.
> 
> Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied to net-next.
Headers have already been updated by other changes.
