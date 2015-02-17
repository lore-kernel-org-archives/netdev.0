From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Tue, 17 Feb 2015 15:45:28 +0100
Message-ID: <54E35408.4060007@redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com>	<20150217090242.GA20254@redhat.com>	<54E31F24.1060705@redhat.com>	<20150217123212.GA6362@redhat.com> <20150217154452.6f62dd77@nial.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Igor Mammedov <imammedo@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150217154452.6f62dd77@nial.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 17/02/2015 15:44, Igor Mammedov wrote:
> As alternative:
> we can filter out hotplugged memory and vhost will continue to work with
> only initial memory.
> So question is id we have to tell vhost about hotplugged memory?

Yes, I think so.

Paolo
