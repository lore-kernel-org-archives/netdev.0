From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 1/6] VSOCK: vsock protocol implementation.
Date: Tue, 6 Nov 2012 06:31:09 -0800 (PST)
Message-ID: <1891962703.13755196.1352212269838.JavaMail.root@vmware.com>
References: <20121106101013.09806f81@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net,
	George Zhang <georgezhang@vmware.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121106101013.09806f81@s6510.linuxnetplumber.net>
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

Hi Stephen,

> You did some scrubbing of the macro's to support multiple kernel
> versions, but there are still some leftovers.
> This code seems to have a lot of "this added in version xxx"
> type comments. These are probably not a good idea to include
> in the mainline kernel code.

Thanks so much for taking a look.  Sorry about that, we'll remove
all such occurrences and send out a new series of patches in a bit.

Thanks!
- Andy
