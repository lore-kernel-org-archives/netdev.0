From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net] b58537a1f56: +89.2% netperf.Throughput_Mbps
Date: Thu, 19 Jun 2014 10:15:09 +0200
Message-ID: <53A29C0D.6080408@redhat.com>
References: <53A10291.7090301@intel.com> <alpine.DEB.2.02.1406181328160.10339@chino.kir.corp.google.com> <53A1F8D9.7070704@redhat.com> <alpine.DEB.2.02.1406181340380.13111@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jet Chen <jet.chen@intel.com>, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, lkp@01.org,
	Fengguang Wu <fengguang.wu@intel.com>
To: David Rientjes <rientjes@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1406181340380.13111@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/18/2014 10:41 PM, David Rientjes wrote:
> On Wed, 18 Jun 2014, Daniel Borkmann wrote:
>
>> One assumption could be that netperf was setting this knob
>> internally and ignoring the result of it (error/success), but
>> that we might need to look up in netperf source to confirm.
>
> Confirmed netperf-2.4.5 doesn't do this.

Ok, thanks for checking, then I fully agree with you.
