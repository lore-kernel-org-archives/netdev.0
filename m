From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/5] forcedeth: several proposed updates for testing
Date: Sun, 07 Oct 2007 16:05:00 -0400
Message-ID: <47093BEC.2010000@garzik.org>
References: <20071006151250.GA17020@havoc.gtf.org>	 <4708F194.7080303@garzik.org> <86802c440710071239x28c41db2hca6dd7c5bb3c411c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756884AbXJGUF3@vger.kernel.org>
In-Reply-To: <86802c440710071239x28c41db2hca6dd7c5bb3c411c@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yinghai Lu wrote:
> On 10/7/07, Jeff Garzik <jeff@garzik.org> wrote:
>> Jeff Garzik wrote:
>>> The 'fe-lock' branch of
>>> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git fe-lock
>> OK, I've successfully tested patches 1-5 on an AMD64 system with
>>
>> 00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)
> 
> need to test that with mcp55 based, that will use MSI.

I would love to see an MSI-X test too (might have to turn on throughput 
mode).

	Jeff
