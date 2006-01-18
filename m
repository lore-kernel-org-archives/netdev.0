From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Tue, 17 Jan 2006 19:36:02 -0500
Message-ID: <43CD8D72.6040501@pobox.com>
References: <20060105181826.GD12313@stusta.de> <20060115161958.07e3c7f1@vitb.dev.rtsoft.ru> <20060115160340.6f8cc7d6@localhost.localdomain> <20060117184834.GD19398@stusta.de> <56a8daef0601171427s75894fid0f8c4f9e2b28e50@mail.gmail.com> <20060118003232.GA28965@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Ronciak <john.ronciak@gmail.com>,
	Adrian Bunk <bunk@stusta.de>,
	Stephen Hemminger <shemminger@osdl.org>,
	Vitaly Bordug <vbordug@ru.mvista.com>, saw@saw.sw.com.sg,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965036AbWARAgq@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060118003232.GA28965@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Tue, Jan 17, 2006 at 02:27:16PM -0800, John Ronciak wrote:
> 
> 
>>Another thing is that removal of the driver (or disabling the config)
>>will hopefully force the issue in that people with these ARCHs will
>>use the e100 and if they have problems we can get them fixed in the
>>e100 driver.  At this point nobody seems to be able to define a "real"
>>problem other than talking about it.

Someone should send me a patch that adds eepro100 to the feature-removal 
doc.

	jeff
