From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/10] mlxsw: Preparations for VRF offload
Date: Fri, 10 Mar 2017 09:39:34 -0800 (PST)
Message-ID: <20170310.093934.263809760539469443.davem@davemloft.net>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932912AbdCJRji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 12:39:38 -0500
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 10 Mar 2017 08:53:33 +0100

> Ido says:
> 
> This patchset aims to prepare the mlxsw driver for VRF offload. The
> follow-up patchsets that introduce VRF support can be found here:
> https://github.com/idosch/linux/tree/idosch-next
> 
> The first four patches are mainly concerned with the netdevice
> notification block. There are no functional changes, but merely
> restructuring to more easily integrate VRF enslavement.
> 
> Patches 5-10 remove various assumptions throughout the code about a
> single virtual router (VR) and also restructure the internal data
> structures to more accurately represent the device's operation.

Series applied, thanks.
