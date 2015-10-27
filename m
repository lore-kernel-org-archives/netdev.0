From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH v8] seccomp, ptrace: add support for dumping seccomp filters
Date: Tue, 27 Oct 2015 01:17:17 +0100
Message-ID: <562EC28D.1070908@iogearbox.net>
References: <1445370612-18843-2-git-send-email-tycho.andersen@canonical.com> <20151020202024.GA5772@redhat.com> <20151020220814.GA3232@hopstrocity> <20151021185146.GA27176@redhat.com> <20151021191533.GD30729@hopstrocity> <20151021210756.GA641@redhat.com> <20151021213306.GF30729@hopstrocity> <20151025153943.GA1912@redhat.com> <CAGXu5jLH++bDe-yf=jVxSxqO0FFLtpGnme9TFp2s-uPSZ4jbSg@mail.gmail.com> <CAGXu5jKj22-obrjhULdYx5+rEzNESHxLh6VZAbWugKr_LzA7kg@mail.gmail.com> <20151027000453.GA3379@hopstrocity>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151027000453.GA3379@hopstrocity>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tycho,

On 10/27/2015 01:04 AM, Tycho Andersen wrote:
> On Mon, Oct 26, 2015 at 04:07:01PM +0900, Kees Cook wrote:
>> On Mon, Oct 26, 2015 at 3:46 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
>>> Cool, thanks. I'll get this into my tree after kernel summit. Thanks
>>> for suffering through all this Tycho!
>>
>> Actually, since this depends on changes in net, could this get pulled
>> in from that direction?
>>
>> Acked-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>
> Can we get the attached patch into net-next?

You need to make a fresh, formal submission of your patch to netdev,
not as an attachment (otherwise patchwork cannot properly pick it up).

Also, indicate the right tree in the subject as: [PATCH net-next] ...

Thanks,
Daniel
