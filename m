From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v3] net: ethernet: support "fixed-link" DT node on nb8800 driver
Date: Mon, 08 Feb 2016 13:37:01 +0000
Message-ID: <yw1xfux3fhmq.fsf@unicorn.mansr.com>
References: <56B4A445.7080402@laposte.net>
	<yw1x1t8ri8dz.fsf@unicorn.mansr.com> <56B4A877.4020800@laposte.net>
	<yw1xsi17gsxl.fsf@unicorn.mansr.com> <56B4ACC4.1000607@laposte.net>
	<yw1xoabvgs7s.fsf@unicorn.mansr.com> <56B4B013.5030407@laposte.net>
	<yw1xk2mjgraf.fsf@unicorn.mansr.com> <56B4B81D.3000108@laposte.net>
	<yw1xfux7gpol.fsf@unicorn.mansr.com> <56B4BDDA.9010708@laposte.net>
	<yw1xbn7vgoux.fsf@unicorn.mansr.com> <56B86F44.3030806@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B86F44.3030806@laposte.net> (Sebastian Frias's message of
	"Mon, 08 Feb 2016 11:34:44 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Frias <sf84@laposte.net> writes:

> On 02/05/2016 04:26 PM, M=E5ns Rullg=E5rd wrote:
>> Sebastian Frias <sf84@laposte.net> writes:
>>
>>> On 02/05/2016 04:08 PM, M=E5ns Rullg=E5rd wrote:
>>>> Sebastian Frias <sf84@laposte.net> writes:
>>>>
>>>>> On 02/05/2016 03:34 PM, M=E5ns Rullg=E5rd wrote:
>>>>>> Sebastian Frias <sf84@laposte.net> writes:
>>>>>>
>>>>>>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>>>>>>
>>>>>> Please change the subject to something like "net: ethernet: nb88=
00:
>>>>>> support fixed-link DT node" and add a comment body.
>>>>>
>>>>> The subject is pretty explicit for such a simple patch, what else
>>>>> could I add that wouldn't be unnecessary chat?
>>>>
>>>> It's customary to include a description body even if it's little m=
ore
>>>> than a restatement of the subject.  Also, while the subject usuall=
y only
>>>> says _what_ the patch does, the body should additionally state _wh=
y_ it
>>>> is needed.
>>>
>>> I understand, but _why_ it is needed is also obvious in this case; =
I
>>> mean, without the patch "fixed-link" cannot be used.
>>
>> Then say so.
>>
>>> Other patches may not be as obvious/simple and thus justify and
>>> require more details.
>>>
>>> Anyway, I added "Properly handles the case where the PHY is not con=
nected
>>> to the real MDIO bus" would that be ok?
>>
>> Have you read Documentation/SubmittingPatches?  Do so (again) and pa=
y
>> special attention to section 2 "Describe your changes."
>
> I just sent v5.

Thanks for your patience.

> If for whatever reason, you or anybody else think that the comment is
> not good, would you mind proposing a comment that would make everybod=
y
> happy so that the patch goes thru?
> And if you or anybody else does not want the patch, could you please
> say so as well?
>
> I have to admit this process (sending patches and getting it reviewed=
)
> could benefit from more clarifications.
> For example, the process could say that at least 2 reviewers must
> agree on it (on the comments made to the patch and on the patch
> itself).
> I could also say that reviewers are to express not only their opinion
> but to clearly and unequivocally accept or reject.
>
> For instance, right now, it is not clear to me if your comments are
> "nice to have" or "blocking" the patch.
> I don't know if the patch is welcome or not, etc.
> So I submitted v5, but maybe it was not even necessary, it's hard to
> know where in the submission process we are.

In this case, it's ultimately up to Dave Miller.  He'll take into
account whatever comments others have made and decide whether he wants
to accept it.

> By the way, I know some people like the command line, email, etc. but
> there ought to be other tools better suited for patch review...

Some kernel subsystems use http://patchwork.ozlabs.org/ to track status
of various patches.

--=20
M=E5ns Rullg=E5rd
