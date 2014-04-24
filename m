From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] pci: Use designated initialization in PCI_VDEVICE
Date: Thu, 24 Apr 2014 23:43:27 +0000
Message-ID: <8514B09D-4F10-4B14-940D-9237425C32BB@intel.com>
References: <1396303119-16766-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <5339E746.4030503@cogentembedded.com> <20140424212246.GG29593@google.com>
 <512BF6D5-D529-4605-B1AB-A6DB7D153E14@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <512BF6D5-D529-4605-B1AB-A6DB7D153E14@intel.com>
Content-Language: en-US
Content-ID: <A6D2CD93074DA441B8F8A818AFFDEBCC@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Apr 24, 2014, at 4:15 PM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:

<snip>
> Adding the missing field in all of those places would also silence the message, but it seemed reasonable to have require that.

I meant "it seemed reasonable to *not* have to require that". Hopefully that helps it make some sense.

-- 
Mark Rustad, Networking Division, Intel Corporation
