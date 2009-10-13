From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.32-rc4] net: VMware virtual Ethernet NIC driver:
	vmxnet3
Date: Tue, 13 Oct 2009 00:16:03 -0700 (PDT)
Message-ID: <20091013.001603.160899793.davem@davemloft.net>
References: <alpine.LRH.2.00.0910121447090.13205@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
        greg@kroah.com, shemminger@linux-foundation.org
To: sbhatewara@vmware.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <alpine.LRH.2.00.0910121447090.13205@sbhatewara-dev1.eng.vmware.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Mon, 12 Oct 2009 15:18:42 -0700 (PDT)

> 
> Ethernet NIC driver for VMware's vmxnet3
> 
> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> 
> This patch adds driver support for VMware's virtual Ethernet NIC: vmxnet3
> Guests running on VMware hypervisors supporting vmxnet3 device will thus have
> access to improved network functionalities and performance.
> 
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
> Signed-off-by: Ronghua Zhang <ronghua@vmware.com>

Ok, looks good, applied to net-2.6, thanks!
