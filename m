From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] Add support for configuring Infiniband GUIDs
Date: Fri, 15 Jul 2016 11:31:59 -0700
Message-ID: <20160715113159.703f9e82@xeon-e3>
References: <20160707210903.24260-1-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: david.laight@aculab.com, netdev@vger.kernel.org
To: Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33407 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbcGOSfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:35:39 -0400
Received: by mail-pf0-f177.google.com with SMTP id y134so17612370pfg.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 11:35:39 -0700 (PDT)
In-Reply-To: <20160707210903.24260-1-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Jul 2016 16:09:03 -0500
Eli Cohen <eli@mellanox.com> wrote:

> Add two NLA's that allow configuration of Infiniband node or port GUIDs
> by referencing the IPoIB net device set over the physical function. The
> format to be used is as follows:
> 
> ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70
> ip link set dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78
> 
> Signed-off-by: Eli Cohen <eli@mellanox.com>

Applied, thanks
