From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v3 0/8] cgroup: Assign subsystem IDs during compile time
Date: Tue, 11 Sep 2012 23:19:07 +0200
Message-ID: <504FAACB.2020704@monom.org>
References: <1347380774-9546-1-git-send-email-wagi@monom.org> <20120911211151.GC7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120911211151.GC7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 09/11/2012 11:11 PM, Tejun Heo wrote:
> Hello,
>
> On Tue, Sep 11, 2012 at 06:26:06PM +0200, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>>
>> Hi,
>>
>> In this version I tried to concentrate on the main topic of this
>> series, so I removed some of the things which were not really needed
>> and I have to admit the result looks much better. So I hope that will
>> simplify the review for you.
>
> Other than the few nits I like the whole series and, given that all
> the changes are entangled with cgroup core, I would like to route it
> through cgroup/for-3.7 if nobody objects.  Daniel, can you please
> rebase on top of the following branch when sending out updated
> version?
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.7

Sure, I'll rebase and update the series tomorrow. Thanks for your 
patience with me.

cheers,
daniel
