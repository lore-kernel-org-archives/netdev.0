From: Tejun Heo <tj@kernel.org>
Subject: Re: [TRIVIAL PATCH V2] Doc: percpu_counter doc code for better readability
Date: Mon, 4 Feb 2013 14:10:03 -0800
Message-ID: <CAOS58YO1VSsbisxSqzcW6n=a+XwcM4F0uHN40OKB9Ok6DSMW7A@mail.gmail.com>
References: <20130204214952.GJ27963@mtj.dyndns.org>
	<20130204221356.29548.35746.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, joe@perches.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130204221356.29548.35746.stgit@dragon>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 4, 2013 at 2:14 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> Help people reading the percpu_counter code, to notice the ifdef
> else statement that seperates CONFIG_SMP.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Acked-by: Tejun Heo <tj@kernel.org>

Jiri, can you please take this?

Thank you.

-- 
tejun
