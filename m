From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/6] VSOCK for Linux upstreaming
Date: Tue, 8 Jan 2013 16:21:10 -0800
Message-ID: <20130109002110.GB5296@kroah.com>
References: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: George Zhang <georgezhang@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 08, 2013 at 03:59:08PM -0800, George Zhang wrote:
> 
> * * *
> 
> This series of VSOCK linux upstreaming patches include latest udpate from
> VMware to address Greg's and all other's code review comments.

Dave, you acked these patches a while ago, and now that I've taken the
VMCI patches that these depend on through my char-misc tree, can I take
these as well?

thanks,

greg k-h
