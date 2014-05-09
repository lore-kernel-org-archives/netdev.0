From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 1/1] Driver for Beckhoff CX5020 EtherCAT master
 module.
Date: Thu, 08 May 2014 23:00:07 -0400 (EDT)
Message-ID: <20140508.230007.1457921998245217898.davem@davemloft.net>
References: <20140506202450.GM1156@newterm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: reksio@newterm.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506202450.GM1156@newterm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Darek Marcinkiewicz <reksio@newterm.pl>
Date: Tue, 6 May 2014 22:24:50 +0200

> This driver adds support for EtherCAT master module located on CCAT
> FPGA found on Beckhoff CX series industrial PCs. The driver exposes
> EtherCAT master as an ethernet interface.
> 
> EtherCAT is a fieldbus protocol defined on top of ethernet and Beckhoff
> CX5020 PCs come with built-in EtherCAT master module located on a FPGA,
> which in turn is connected to a PCI bus.
> 
> Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>

Applied, thanks Dariusz.
