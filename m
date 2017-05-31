From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/1] netvsc: Add #include's for csum_* function
 declarations
Date: Wed, 31 May 2017 15:59:31 -0700
Message-ID: <1496271571.2618.56.camel@perches.com>
References: <1496166184-19805-1-git-send-email-mikelley@microsoft.com>
         <20170531.135952.1314266532351768088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
        jasowang@redhat.com, leann.ogasawara@canonical.comi,
        marcelo.cerri@canonical.com, sthemmin@microsoft.com
To: David Miller <davem@davemloft.net>, mikelley@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0219.hostedemail.com ([216.40.44.219]:38204 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751108AbdEaW7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 18:59:36 -0400
In-Reply-To: <20170531.135952.1314266532351768088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-31 at 13:59 -0400, David Miller wrote:
> From: Michael Kelley <mikelley@microsoft.com>
> Date: Tue, 30 May 2017 10:43:04 -0700
> 
> > Add direct #include statements for declarations of csum_tcpudp_magic()
> > and csum_ipv6_magic(). While the needed #include's are picked up
> > indirectly for the x86 architecture, they aren't on other
> > architectures, resulting in compile errors.
> > 
> > Signed-off-by: Michael Kelley <mikelley@microsoft.com>
> 
> Applied, thank you.

Did you apply this one or the v2?
