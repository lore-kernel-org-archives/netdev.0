From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 05 May 2010 19:03:54 -0700
Message-ID: <C807719A.2E910%scofeldm@cisco.com>
References: <89E2752CFA8EC044846EB8499819134102AF2896F5@EXCH-MBX-4.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	Pankaj Thakkar <pthakkar@vmware.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Dmitry Torokhov <dtor@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <89E2752CFA8EC044846EB8499819134102AF2896F5@EXCH-MBX-4.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/5/10 10:29 AM, "Dmitry Torokhov" <dtor@vmware.com> wrote:

> It would not be a binary blob but software properly released under GPL.
> The current plan is for the shell to enforce GPL requirement on the
> plugin code, similar to what module loaded does for regular kernel
> modules.

On 5/5/10 3:05 PM, "Shreyas Bhatewara" <sbhatewara@vmware.com> wrote:

> The plugin image is not linked against Linux kernel. It is OS agnostic infact
> (Eg. same plugin works for Linux and Windows VMs)

Are there any issues with injecting the GPL-licensed plug-in into the
Windows vmxnet3 NDIS driver?

-scott
