From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 00/02] small changes to Documentation/networking/00-INDEX
 and scaling.txt
Date: Thu, 11 Aug 2011 20:34:53 -0400
Message-ID: <4E44752D.1080905@google.com>
References: <1312899648.5889.14.camel@gopher.nyc.corp.google.com> <4E418030.2010102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, linux-doc@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4E418030.2010102@hp.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A previous patch that added Documentation/networking/scaling.txt missed
some feedback and lacked a line to 00-INDEX. This trivial patch set 

[1/2] adds descriptions to 00-INDEX for all currently unlisted files and
[2/2] revises scaling.txt to clarify interrupt coalescing, hyperthreading
      and cache affinity.

  willem

