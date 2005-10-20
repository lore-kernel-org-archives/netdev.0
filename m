From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.14-rc3] sundance: include MII address 0 in PHY probe
Date: Thu, 20 Oct 2005 10:07:13 -0400
Message-ID: <4357A491.8070901@pobox.com>
References: <10192005080734.15936@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932097AbVJTOHX@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <10192005080734.15936@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Include MII address 0 at the end of the PHY scan.  This covers the
> entire range of possible MII addresses.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

applied
