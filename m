From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: RE: [PATCH RFC 63/77] qlcnic: Update MSI/MSI-X interrupts
 enablement code
Date: Tue, 8 Oct 2013 22:46:51 +0000
Message-ID: <ADFE82A996F10145934E45547759F7638C923C26@avmb3.qlogic.org>
References: <cover.1380703262.git.agordeev@redhat.com>
 <c92efbde96541d08f37510422c096d543bb01279.1380703263.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        "Ingo Molnar" <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci <linux-pci@vger.kernel.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "linux390@de.ibm.com" <linux390@de.ibm.com>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        "x86@kernel.org" <x86@kernel.org>,
        "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>
To: Alexander Gordeev <agordeev@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <c92efbde96541d08f37510422c096d543bb01279.1380703263.git.agordeev@redhat.com>
Content-Language: en-US
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Alexander Gordeev [mailto:agordeev@redhat.com]
> Sent: Wednesday, October 02, 2013 3:49 AM
> To: linux-kernel
> Cc: Alexander Gordeev; Bjorn Helgaas; Ralf Baechle; Michael Ellerman;
> Benjamin Herrenschmidt; Martin Schwidefsky; Ingo Molnar; Tejun Heo; Dan
> Williams; Andy King; Jon Mason; Matt Porter; linux-pci; linux-mips@linux-
> mips.org; linuxppc-dev@lists.ozlabs.org; linux390@de.ibm.com; linux-
> s390@vger.kernel.org; x86@kernel.org; linux-ide@vger.kernel.org;
> iss_storagedev@hp.com; linux-nvme@lists.infradead.org; linux-
> rdma@vger.kernel.org; netdev; e1000-devel@lists.sourceforge.net; Dept-
> Eng Linux Driver; Solarflare linux maintainers; VMware, Inc.; linux-scsi
> Subject: [PATCH RFC 63/77] qlcnic: Update MSI/MSI-X interrupts enablement
> code
> 
> As result of recent re-design of the MSI/MSI-X interrupts enabling pattern
> this driver has to be updated to use the new technique to obtain a optimal
> number of MSI/MSI-X interrupts required.
> 
 "We will test this change for the driver and provide feedback."

> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>

Thanks,
Himanshu
