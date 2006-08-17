From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][PATCH 0/75] pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 09:25:25 -0400
Message-ID: <44E46E45.5010704@garzik.org>
References: <20060817042634.0.CrzcY28443.28439.michal@ltg01-fedora.pl>	 <20060817055814.GA14950@kroah.com> <44E46280.2020109@garzik.org> <6bffcb0e0608170609g3926cad7wd3b4737d869ed794@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932493AbWHQNZ3@vger.kernel.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
In-Reply-To: <6bffcb0e0608170609g3926cad7wd3b4737d869ed794@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Actually, I stand corrected:  netdev-2.6.git#upstream does not contain a 
pci_register_driver() patch.

Send the drivers/net piece along to me and I'll apply it.

	Jeff
