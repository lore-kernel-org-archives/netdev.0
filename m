From: Michel Machado <michel@digirati.com.br>
Subject: Re: Linux XIA - merge proposal
Date: Tue, 17 Mar 2015 08:37:27 -0400
Message-ID: <55082007.4080401@digirati.com.br>
References: <54F5EF6E.9090303@digirati.com.br> <CAErSpo6hUHYXrdB0+1WysD=AMuX3eawqSokTngR4s2tmmuakqA@mail.gmail.com> <550301B6.3090302@digirati.com.br> <20150315093752.GA29005@kroah.com> <550558E5.2030309@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Dave Airlie <airlied@gmail.com>
To: Oded Gabbay <oded.gabbay@amd.com>,
	Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <550558E5.2030309@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/15/2015 06:03 AM, Oded Gabbay wrote:
> Hi Michel,
>
> Although I don't know you and I'm not familiar with XIA, I would like to
> encourage you to listen to Greg and continue with your efforts to
> upstream XIA.
>
> I can tell you, from my recent experience of upstreaming AMD's HSA
> driver to drm (amdkfd), that I understand your response/frustration.
> However, you need to understand that the feedback you got is not because
> the maintainers/devs don't want your code. It is because they want your
> code to be in the best shape it can be before merging it to the kernel.
> Once it is in the kernel, it is distributed to millions of people and it
> is maintained practically forever.
>
>  From my experience, the major changes that make your code better are
> usually done *before* upstreaming the code. Once the maintainers/devs
> realize that the code has reached some level of compliance with kernel
> standards, and the code can't get any better by leaving it outside the
> kernel, I'm sure they will accept the code. Especially if they will see
> that you are dedicated to improving it.
>
> Please see this enlightening post from drm maintainer, Dave Airlie,
> about trying to push code to upstream kernel:
> http://airlied.livejournal.com/80112.html
>
> It is called:
> "you have a long road to walk, but first you have to leave the house (or
> why publishing code is STEP ZERO)."
>
> BTW, I believe I was one of the reasons he wrote that post (it was
> published shortly after I published amdkfd's code) :)
>
> So bottom line, keep working on it. People gave you pointers what to do.
> Follow that and don't give up. In the end, I'm sure you will be very
> happy once the code is merged into the mainline kernel.
>
> Good luck,
>
>      Oded

Hi Oded,

    Thank you for sharing your experience. Dave Airlie's perspective 
helps. I'm going to walk the road "with a little help from friends."

[ ]'s
Michel Machado
