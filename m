From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (0/7) device_probe enhancement
Date: Tue, 23 Sep 2003 20:25:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F70E47F.6020507@pobox.com>
References: <20030923144721.6001c598.shemminger@osdl.org> <20030923163910.4239ac33.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030923163910.4239ac33.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 23 Sep 2003 14:47:21 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> 
>>This comes from Al Viro's net device patchset and is updated for
>>2.6.0-test5 latest.  It adds a second probe list for network devices
>>that are compiled into the kernel, but allocate their own network
>>device rather than being handed a device.  It is part of the
>>incremental changes to have all network devices using dynamic
>>allocation.
> 
> 
> This all looks fine to me.  Jeff, what do you think?  Are you gonna
> merge it if it's ok to you?


Merging right now.  I have some minor nits to pick, but they can be 
cleaned up later.
