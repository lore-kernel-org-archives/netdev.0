From: Raju Srivastava <raju.s.linux@gmail.com>
Subject: Re: virtio-net zero-copy
Date: Tue, 19 May 2009 22:39:33 +0800
Message-ID: <bd8f29360905190739n78900b8ep7ca4cdfa8f0259a8@mail.gmail.com>
References: <bd8f29360905180619g3ccee719m268f57e63a88fd4f@mail.gmail.com>
	 <4A1169EE.3050603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A1169EE.3050603@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 18, 2009 at 10:00 PM, Avi Kivity <avi@redhat.com> wrote:
> Raju Srivastava wrote:
>>
>> Greetings,
>>
>> Could someone let me know if current virtio-net supports zero-copy? I
>> see some discussion here:
>> http://thread.gmane.org/gmane.comp.emulators.kvm.devel/28061/
>> (copyless virtio net thoughts) and it looks like the copyless
>> virtio-net is not supported by KVM yet.
>
> That is correct.

Thank you for letting me know this.

>> If this is true, then is there
>> any plan to add the zero copy to the virtio-net?
>>
>
> Yes, but it will be a difficult journey.

That's great. I'm looking forward to it. It's said Xen NetChannel 2
has some new features including the zero-copy. Though it would be a
difficult journey, it's really worth, right?

Thanks & Regards,
Raju
